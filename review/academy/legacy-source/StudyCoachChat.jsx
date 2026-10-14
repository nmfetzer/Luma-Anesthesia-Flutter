import { useState, useEffect, useRef } from 'react';
import { Send, Bot, Loader2, X } from 'lucide-react';
import { base44 } from '@/api/base44Client';
import AIMessageMarkdown from '@/components/AIMessageMarkdown';

function MessageBubble({ message }) {
  const isUser = message.role === 'user';
  const isThinking = !isUser && !message.content && message.tool_calls?.some(tc =>
    ['pending', 'running', 'in_progress'].includes(tc.status)
  );

  if (isThinking) {
    return (
      <div className="flex justify-start">
        <div className="bg-secondary rounded-2xl px-4 py-3 max-w-[85%] flex items-center gap-2">
          <Loader2 className="w-3.5 h-3.5 text-muted-foreground animate-spin shrink-0" />
          <span className="text-xs text-muted-foreground">Analyzing your progress…</span>
        </div>
      </div>
    );
  }

  if (!message.content && !message.tool_calls?.length) return null;

  return (
    <div className={`flex ${isUser ? 'justify-end' : 'justify-start'}`}>
      <div className={`rounded-2xl px-4 py-3 max-w-[85%] text-sm leading-relaxed ${
        isUser
          ? 'bg-primary text-white'
          : 'bg-secondary text-foreground'
      }`}>
        {isUser ? (
          <p>{message.content}</p>
        ) : (
          <AIMessageMarkdown content={message.content || ''} className="prose prose-sm max-w-none prose-p:my-1 prose-ul:my-1 prose-li:my-0.5 prose-strong:font-semibold" />
        )}
      </div>
    </div>
  );
}

export default function StudyCoachChat({ onClose }) {
  const [conversation, setConversation] = useState(null);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);
  const bottomRef = useRef(null);

  // Create conversation and send opening message on mount
  useEffect(() => {
    async function init() {
      const conv = await base44.agents.createConversation({
        agent_name: 'study_coach',
        metadata: { name: 'Daily Study Session' },
      });
      setConversation(conv);

      // Fetch the current user's FlashcardProgress to pass as context
      let progressContext = '';
      try {
        const me = await base44.auth.me();
        if (me) {
          const progress = await base44.entities.FlashcardProgress.filter({ created_by_id: me.id });
          if (progress && progress.length > 0) {
            const summary = progress.map(p =>
              `deck_id: ${p.deck_id || p.set_id}, cards_seen: ${(p.cards_seen || []).length}, total_cards: ${p.total_cards || '?'}, completed: ${p.completed || false}, last_studied: ${p.last_studied || 'never'}`
            ).join('\n');
            progressContext = `\n\nHere is my current FlashcardProgress data:\n${summary}`;
          }
        }
      } catch (_) {}

      // Send an auto-opening message with progress context attached
      await base44.agents.addMessage(conv, {
        role: 'user',
        content: `Hi! What should I study today?${progressContext}`,
      });

      const unsub = base44.agents.subscribeToConversation(conv.id, (data) => {
        setMessages(data.messages || []);
      });
      return unsub;
    }

    let unsub;
    init().then(fn => { unsub = fn; });
    return () => { if (unsub) unsub(); };
  }, []);

  // Scroll to bottom on new messages
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const sendMessage = async () => {
    if (!input.trim() || !conversation || sending) return;
    const text = input.trim();
    setInput('');
    setSending(true);
    await base44.agents.addMessage(conversation, { role: 'user', content: text });
    setSending(false);
  };

  const handleKey = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const visibleMessages = messages.filter(m => m.role === 'user' || m.role === 'assistant');

  return (
    <div className="flex flex-col h-full bg-background">
      {/* Header */}
      <div className="shrink-0 flex items-center gap-3 px-4 py-3 border-b border-border/50">
        <div className="w-8 h-8 rounded-xl bg-purple-50 border border-purple-100 flex items-center justify-center shrink-0">
          <Bot className="w-4 h-4 text-purple-600" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="font-semibold text-sm text-foreground leading-none">Study Coach</p>
          <p className="text-[10px] text-muted-foreground mt-0.5">Daily session planner</p>
        </div>
        {onClose && (
          <button onClick={onClose} aria-label="Close" className="p-3 min-w-[44px] min-h-[44px] rounded-lg hover:bg-secondary transition-colors flex items-center justify-center">
            <X className="w-4 h-4 text-muted-foreground" />
          </button>
        )}
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3 scroll-area">
        {visibleMessages.length === 0 && (
          <div className="flex justify-start">
            <div className="bg-secondary rounded-2xl px-4 py-3 max-w-[85%] flex items-center gap-2">
              <Loader2 className="w-3.5 h-3.5 text-muted-foreground animate-spin shrink-0" />
              <span className="text-xs text-muted-foreground">Analyzing your progress…</span>
            </div>
          </div>
        )}
        {visibleMessages.map((msg, i) => (
          <MessageBubble key={i} message={msg} />
        ))}
        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <div className="shrink-0 px-4 py-3 border-t border-border/50">
        <div className="flex items-center gap-2">
          <input
            className="flex-1 px-4 py-2.5 rounded-xl bg-secondary border border-border text-sm outline-none focus:ring-2 focus:ring-primary/30 transition"
            placeholder="Ask your study coach…"
            value={input}
            onChange={e => setInput(e.target.value)}
            onKeyDown={handleKey}
            disabled={sending}
          />
          <button
            onClick={sendMessage}
            disabled={!input.trim() || sending}
            aria-label="Send message"
            className="w-11 h-11 min-w-[44px] min-h-[44px] rounded-xl bg-primary text-white flex items-center justify-center shrink-0 disabled:opacity-40 active:scale-95 transition-all"
          >
            <Send className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}