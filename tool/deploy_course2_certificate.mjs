import fs from 'node:fs';
import {call} from './load_course2_private.mjs';
const dir='supabase/functions/ce-course2-certificate/';
console.log(call('deploy_edge_function',{
  name:'ce-course2-certificate',entrypoint_path:'index.ts',
  import_map_path:'deno.json',verify_jwt:true,
  files:['index.ts','renderer.mjs','deno.json','private_assets.mjs'].map(name=>({
    name,content:fs.readFileSync(dir+name,'utf8'),
  })),
}));
