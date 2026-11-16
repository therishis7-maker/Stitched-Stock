STITCHSTOCK PERSONAL — MOBILE SETUP GUIDE

What this is:
A personal inventory website. One login, online database, private stock records.
Includes Shirts, Trousers, Pants, stock-in, sale-out, history and CSV download.

PART A — Create the online database
1. Open https://supabase.com in Chrome and create/sign in to your account.
2. Create a new project called StitchStock-Personal. Save the database password privately.
3. Wait until the project is ready.
4. Open SQL Editor > New query.
5. Open schema.sql from this package, copy all its text, paste into SQL Editor, then press Run.
6. Open Project Settings > API (or Data API / API Keys depending on dashboard layout).
7. Copy Project URL and the anon/public key. Never copy or share service_role/secret key.

PART B — Connect this app
1. Open index.html in a text editor app that can edit HTML (for example, a code editor).
2. Find PASTE_SUPABASE_PROJECT_URL and replace it with your Project URL, keeping the quote marks.
3. Find PASTE_SUPABASE_ANON_KEY and replace it with your anon/public key, keeping quote marks.
4. Save index.html.

PART C — Put it online free
One straightforward route is GitHub Pages:
1. Sign in at https://github.com in Chrome and create a new public repository named stitchstock-personal.
2. Upload the edited index.html file to the repository root (not inside another folder).
3. In the repository, open Settings > Pages.
4. Under Build and deployment choose Deploy from a branch; branch main, folder /(root); Save.
5. Wait for GitHub Pages to publish. The website address will appear in that Pages section.
6. Open the website address. Create your account with your email and a strong password.
7. If email confirmation is enabled, confirm the email, then log in.

FIRST LOGIN:
When your account is created, the app creates its three product rows automatically on first load.
If they do not appear, refresh the page once and check that the SQL setup completed successfully.

IMPORTANT SECURITY:
- Only use your Supabase anon/public key in the website. Never put service_role or secret keys in index.html.
- The database policies restrict records to the signed-in account.
- Anyone who can create an account in this Supabase project can create their own separate inventory; they cannot read your rows.
- Keep your Supabase account secure and do not share your password.
- This is an initial personal MVP. Keep separate backups/exports of important business records.
