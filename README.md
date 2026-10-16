# StudyShelf — Educational PDF Library

A responsive frontend starter for an educational PDF download website. The homepage includes search, categories, sorting, level filters, sample PDF cards, legal-page placeholders, and a browser-only demo admin panel.

## Important status

This package is a **front-end prototype**, not a production multi-user upload system yet. The Admin panel saves demo entries in the current browser's local storage; attached demo PDFs are limited to 2 MB and are not shared with other visitors. Do not treat this browser-only panel as secure authentication. The sample listings are placeholders, not real PDF downloads.

For a public production launch, connect Supabase Auth + Storage + Postgres, implement server-side admin authorization, and replace demo listings with licensed PDFs you have permission to distribute. A SQL starter is in `supabase/schema.sql`.

## Preview locally

1. Extract the ZIP.
2. Open `index.html` in Chrome or Edge. No build tools are required for the prototype.
3. Search/filter the sample library. Click **Admin** to add a demo resource.

## Free static hosting with Netlify

1. Create a GitHub repository, for example `studyshelf-pdf-library`.
2. Upload `index.html`, `README.md`, `netlify.toml`, and the `supabase` folder.
3. Sign in at Netlify and choose **Add new site → Import an existing project**.
4. Connect the GitHub repository. Set build command to blank and publish directory to `.`.
5. Deploy. Netlify will provide a public `*.netlify.app` URL. You can attach a custom domain later.

Alternative: GitHub Pages can host the static prototype from repository Settings → Pages → Deploy from a branch. Static hosting does not itself provide secure admin uploads or a database.

## Production backend setup (Supabase free tier availability/limits may change)

1. Create a Supabase project.
2. In **SQL Editor**, run `supabase/schema.sql`.
3. In **Storage**, create a bucket named `pdfs` as **private**. Private storage is recommended for controlled uploads/downloads; implement signed URLs for authorised access. If every file is intentionally public and redistribution is allowed, a public bucket is simpler but cannot provide access control.
4. Enable Supabase Auth. Create an administrator user, then set that user's UUID in `public.admin_users` using the SQL editor. Never place a service-role key in browser code.
5. Build the production UI against Supabase's publishable/anon key only. Enforce permissions through RLS and Storage policies. For admin operations requiring elevated privileges, use a server-side function/Netlify Function with secrets stored in environment variables.
6. Test as anonymous visitor, signed-in non-admin, and admin. Confirm non-admins cannot upload/delete files or modify resource metadata.
7. Update Privacy Policy, Contact, Disclaimer, and copyright/takedown process before launch.

## Suggested data flow

- Public visitors: read only `published = true` resources.
- Admin: sign in through Supabase Auth; upload permitted PDFs to Storage; create/update metadata.
- Downloads: create short-lived signed URLs from a server-validated request if using a private bucket.
- Never upload copyrighted books, paid course material, exam papers, or government documents unless you have permission or they are legally redistributable.

## Files

- `index.html` — responsive, interactive demo frontend
- `supabase/schema.sql` — database tables and row-level security starter
- `netlify.toml` — basic static deployment/security headers

## Before production

- Replace sample listings with verified files and correct file sizes/page counts.
- Add real authentication, server-validated admin role checks, and secure Storage upload/download flow.
- Add rate limits, file size/type validation, malware scanning, abuse reporting, and backup/retention rules.
- Add real support contact details and complete legal policies.
