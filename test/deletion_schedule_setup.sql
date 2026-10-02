-- Disposable-only scheduler adapters: no external HTTP or real scheduled jobs.
create schema net;
create schema cron;
create function net.http_post(url text,headers jsonb,body jsonb,timeout_milliseconds integer)
returns bigint language sql as $$ select 77::bigint $$;
create function cron.schedule(text,text,text)
returns bigint language sql as $$ select 88::bigint $$;
