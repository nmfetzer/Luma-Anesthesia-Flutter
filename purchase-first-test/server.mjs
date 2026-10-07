import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {randomBytes} from 'node:crypto';
import {act,createWorkspace,products} from './core.mjs';
const root=path.dirname(fileURLToPath(import.meta.url));
// State lives outside the deployed static bundle. Fictional .test addresses only.
const statePath=process.env.CE_PREVIEW_STATE||path.join(root,'.test-state.json');
const data=fs.existsSync(statePath)?JSON.parse(fs.readFileSync(statePath,'utf8')):{};
function save(){fs.writeFileSync(statePath+'.tmp',JSON.stringify(data));fs.renameSync(statePath+'.tmp',statePath);}
const types={'.html':'text/html','.js':'text/javascript','.css':'text/css','.ttf':'font/ttf'};
const server=http.createServer(async(req,res)=>{
  res.setHeader('Access-Control-Allow-Origin','*');
  res.setHeader('Access-Control-Allow-Headers','Content-Type,X-Test-Workspace');
  res.setHeader('Access-Control-Allow-Methods','GET,POST,OPTIONS');
  res.setHeader('Cache-Control','no-store');
  res.setHeader('X-Content-Type-Options','nosniff');
  const send=(code,x)=>{res.writeHead(code,{'Content-Type':'application/json'});res.end(JSON.stringify(x));};
  if(req.method==='OPTIONS'){res.writeHead(204);return res.end();}
  const url=new URL(req.url,'http://localhost');
  try{
    if(url.pathname.startsWith('/api/')){
      if(url.pathname==='/api/catalog'&&req.method==='GET')return send(200,{testOnly:true,products});
      if(req.method!=='POST')return send(405,{error:'POST required.'});
      let raw='';for await(const chunk of req){raw+=chunk;if(raw.length>8192)return send(413,{error:'Request too large.'});}
      const body=JSON.parse(raw||'{}');
      if(url.pathname==='/api/workspace'){
        for(const [k,v] of Object.entries(data))if(Date.now()-v.created>86400000)delete data[k];
        if(Object.keys(data).length>=1000)return send(429,{error:'Test capacity reached.'});
        const id=randomBytes(24).toString('hex');data[id]=createWorkspace();save();
        return send(200,{id,testOnly:true});
      }
      const w=data[req.headers['x-test-workspace']];
      if(!w)return send(401,{error:'Test session not found. Start a new test.'});
      try{const result=act(w,url.pathname.slice(5),body);save();return send(200,result);}
      catch(e){save();throw e;}
    }
    if(req.method!=='GET')return send(405,{error:'GET required.'});
    const name=url.pathname==='/'?'index.html':url.pathname.slice(1);
    const file=path.resolve(root,'public',name);
    if(!file.startsWith(path.join(root,'public')+path.sep)||!fs.existsSync(file)||!fs.statSync(file).isFile())return send(404,{error:'Not found.'});
    res.writeHead(200,{'Content-Type':types[path.extname(file)]||'application/octet-stream'});fs.createReadStream(file).pipe(res);
  }catch(e){send(e.status||400,{error:e.status?e.message:'Invalid test request.'});}
});
server.listen(Number(process.env.PORT||4317),'0.0.0.0',()=>console.log('Isolated CE checkout simulation on port '+(process.env.PORT||4317)));
