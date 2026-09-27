import fs from 'node:fs';
const rows=fs.readFileSync('docs/quick-reference-audit/source-evidence.jsonl','utf8').trim().split('\n').map(JSON.parse);
const specs=JSON.parse(process.argv[2]);
for(const [index,pattern,max=8,radius=400] of specs){
 const row=rows[index], text=(row.content??'').replace(/\s+/g,' ');
 console.log(`\nSOURCE ${index}: ${row.url}`);
 let end=-1, n=0;
 for(const m of text.matchAll(new RegExp(pattern,'gi'))){
  if(m.index<end)continue;
  const start=Math.max(0,m.index-radius);end=m.index+m[0].length+radius;
  console.log(text.slice(start,end));if(++n>=max)break;
 }
}
