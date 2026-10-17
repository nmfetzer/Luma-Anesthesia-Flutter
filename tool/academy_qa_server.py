"""LOCAL-ONLY QA bridge. Never deploy; fixed synthetic account in local Postgres.
Serves the compiled Flutter QA harness and runs the same migration/RPCs.
No production connection, credentials or authentication claims are accepted.
"""
import json
import subprocess
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

FUNCTIONS = {
    "academy_catalog": [],
    "academy_progress": [],
    "academy_level": ["p_level", "p_version"],
    "academy_mark": ["p_level", "p_version", "p_kind", "p_item"],
    "academy_document": ["p_level", "p_version", "p_kind"],
    "academy_submit": ["p_level", "p_version", "p_kind", "p_scope", "p_attempt", "p_answers"],
}
def quote(value):
    text = json.dumps(value) if isinstance(value, dict) else str(value)
    return "'" + text.replace("'", "''") + "'"

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/home/user/workspace/academy-qa-web", **kwargs)
    def do_POST(self):
        fn = self.path.removeprefix("/rpc/")
        if fn not in FUNCTIONS or int(self.headers.get("Content-Length", "0")) > 20000:
            self.send_error(400)
            return
        try:
            params = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
            args = ",".join(quote(params[key]) for key in FUNCTIONS[fn])
            sql = (
                "begin;set local role authenticated;"
                "set local request.jwt.claim.sub='00000000-0000-4000-8000-000000000001';"
                f"select to_json(public.{fn}({args}));commit;"
            )
            result = subprocess.run(
                ["sudo", "-u", "postgres", "psql", "-XAtq", "-v", "ON_ERROR_STOP=1",
                 "-d", "academy_connection_test"],
                input=sql, text=True, capture_output=True, check=True)
            body = result.stdout.strip().encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body)
        except Exception:
            self.send_error(400, "Local QA request failed")

if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", 8124), Handler).serve_forever()
