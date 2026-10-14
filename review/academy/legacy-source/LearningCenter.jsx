import { useState, useEffect } from 'react';
import { BookOpen, HelpCircle, Lightbulb, ChevronDown, ChevronUp } from 'lucide-react';
import { base44 } from '@/api/base44Client';
import { motion, AnimatePresence } from 'framer-motion';

export default function LearningCenter({ providerName }) {
  const [tab, setTab] = useState('flashcards');
  const [sets, setSets] = useState([]);
  const [quizzes, setQuizzes] = useState([]);
  const [guides, setGuides] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedSet, setSelectedSet] = useState(null);
  const [cardIndex, setCardIndex] = useState(0);
  const [flipped, setFlipped] = useState(false);

  useEffect(() => {
    loadData();
  }, [tab]);

  const loadData = async () => {
    setLoading(true);
    try {
      if (tab === 'flashcards') {
        const allSets = await base44.entities.FlashcardSet.list();
        setSets(allSets || []);
      } else if (tab === 'quiz') {
        const allQuiz = await base44.entities.QuizQuestion.list();
        setQuizzes(allQuiz || []);
      } else if (tab === 'guides') {
        const allGuides = await base44.entities.StudyGuide.list();
        setGuides(allGuides || []);
      }
    } catch (e) {
      console.error('Load error:', e);
    } finally {
      setLoading(false);
    }
  };

  const handleFlashcardSetClick = async (set) => {
    setSelectedSet(set);
    setCardIndex(0);
    setFlipped(false);
  };

  if (selectedSet && tab === 'flashcards') {
    return (
      <div className="flex flex-col gap-4">
        <button
          onClick={() => setSelectedSet(null)}
          className="text-primary text-sm font-semibold flex items-center gap-2 mb-2"
        >
          ← Back to Sets
        </button>

        <div className="text-center">
          <h2 className="font-bold text-lg text-foreground mb-1">{selectedSet.title}</h2>
          <p className="text-xs text-muted-foreground">{selectedSet.card_count || 0} cards</p>
        </div>

        {/* Flashcard */}
        <motion.div
          onClick={() => setFlipped(!flipped)}
          className="w-full h-64 rounded-2xl bg-gradient-to-br from-primary/20 to-primary/5 border-2 border-primary/30 flex items-center justify-center cursor-pointer shadow-md"
          animate={{ rotateY: flipped ? 180 : 0 }}
          transition={{ duration: 0.3 }}
        >
          <div className="text-center px-6">
            <p className="text-xs text-muted-foreground uppercase tracking-wide mb-3">
              {flipped ? 'Answer' : 'Question'}
            </p>
            <p className="text-lg font-semibold text-foreground leading-relaxed">
              Loading...
            </p>
          </div>
        </motion.div>

        <div className="flex items-center justify-between text-xs text-muted-foreground">
          <span>Card {cardIndex + 1}</span>
          <span>{cardIndex + 1} / {selectedSet.card_count}</span>
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => setCardIndex(Math.max(0, cardIndex - 1))}
            disabled={cardIndex === 0}
            className="flex-1 py-3 rounded-xl bg-secondary text-foreground font-semibold disabled:opacity-40"
          >
            Previous
          </button>
          <button
            onClick={() => setCardIndex(Math.min(selectedSet.card_count - 1, cardIndex + 1))}
            disabled={cardIndex === selectedSet.card_count - 1}
            className="flex-1 py-3 rounded-xl bg-primary text-white font-semibold disabled:opacity-40"
          >
            Next
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      {/* Tab Navigation */}
      <div className="flex gap-2 rounded-xl bg-secondary p-1">
        {[
          { id: 'flashcards', label: 'Flashcards', icon: BookOpen },
          { id: 'quiz', label: 'Quizzes', icon: HelpCircle },
          { id: 'guides', label: 'Guides', icon: Lightbulb },
        ].map(t => (
          <button
            key={t.id}
            onClick={() => setTab(t.id)}
            className={`flex-1 py-2 rounded-lg text-xs font-semibold flex items-center justify-center gap-1 transition-all ${
              tab === t.id ? 'bg-primary text-white shadow-sm' : 'text-muted-foreground'
            }`}
          >
            <t.icon className="w-3.5 h-3.5" />
            {t.label}
          </button>
        ))}
      </div>

      {/* Content */}
      {loading ? (
        <div className="flex justify-center py-12">
          <div className="w-6 h-6 border-2 border-primary border-t-transparent rounded-full animate-spin" />
        </div>
      ) : tab === 'flashcards' ? (
        <div className="space-y-3">
          {sets.length === 0 ? (
            <p className="text-center text-muted-foreground py-8 text-sm">No flashcard sets yet</p>
          ) : (
            sets.map(set => (
              <motion.button
                key={set.id}
                onClick={() => handleFlashcardSetClick(set)}
                className="w-full p-4 bg-card border border-border rounded-2xl text-left hover:shadow-md transition-all"
                whileHover={{ y: -2 }}
              >
                <p className="font-semibold text-foreground">{set.title}</p>
                <p className="text-xs text-muted-foreground mt-1">{set.card_count || 0} cards</p>
              </motion.button>
            ))
          )}
        </div>
      ) : tab === 'quiz' ? (
        <div className="space-y-3">
          {quizzes.length === 0 ? (
            <p className="text-center text-muted-foreground py-8 text-sm">No quizzes yet</p>
          ) : (
            quizzes.map(q => (
              <div key={q.id} className="p-4 bg-card border border-border rounded-2xl">
                <p className="font-semibold text-sm text-foreground">{q.question}</p>
                <div className="flex items-center justify-between mt-2">
                  <span className="text-[10px] px-2 py-1 bg-secondary rounded-full text-muted-foreground">{q.category}</span>
                  <span className="text-[10px] px-2 py-1 bg-blue-50 text-blue-600 rounded-full">{q.difficulty}</span>
                </div>
              </div>
            ))
          )}
        </div>
      ) : (
        <div className="space-y-3">
          {guides.length === 0 ? (
            <p className="text-center text-muted-foreground py-8 text-sm">No study guides yet</p>
          ) : (
            guides.map(g => (
              <div key={g.id} className="p-4 bg-card border border-border rounded-2xl">
                <p className="font-semibold text-foreground">{g.title}</p>
                <div className="flex items-center justify-between mt-2">
                  <span className="text-[10px] text-muted-foreground">{g.category}</span>
                  <span className="text-[10px] text-muted-foreground">{g.estimated_read_time}</span>
                </div>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  );
}