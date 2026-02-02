# 🔒 Security Policy

## Environment Variables

This project requires the following environment variables. **Never commit `.env` file to version control.**

### Setup Instructions

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Fill in your actual credentials:

#### Supabase (Required)
- Create a project at [Supabase](https://supabase.com)
- Get credentials from: Project Settings → API
- `PUBLIC_SUPABASE_URL`: Your project URL
- `PUBLIC_SUPABASE_ANON_KEY`: Public anonymous key (safe to expose to client)

#### Cloudflare R2 (Required for image uploads)
- Create an R2 bucket at [Cloudflare Dashboard](https://dash.cloudflare.com)
- Generate API tokens at [API Tokens](https://dash.cloudflare.com/profile/api-tokens)
- Enable public access for the bucket
- `R2_ACCOUNT_ID`: Your Cloudflare account ID
- `R2_ACCESS_KEY_ID`: R2 access key ID
- `R2_SECRET_ACCESS_KEY`: R2 secret access key (keep secure!)
- `R2_BUCKET_NAME`: Your R2 bucket name
- `R2_PUBLIC_URL`: Public URL for your bucket (format: `https://pub-{account-id}.r2.dev`)

## Security Features

### ✅ Implemented
- **Authentication**: Supabase Auth with email/password and OAuth providers
- **Authorization**: Role-based access control (admin, moderator, user)
- **SQL Injection Protection**: Parameterized queries via Supabase SDK
- **XSS Protection**: Automatic HTML escaping by Svelte
- **CSRF Protection**: Built-in SvelteKit CSRF protection
- **File Upload Validation**:
  - File type checking (images only)
  - File size limits (5MB per image)
  - Maximum 10 images per post
- **Row Level Security (RLS)**: Database-level access control via Supabase

### ⚠️ Security Considerations

1. **Environment Variables**
   - Never commit `.env` file
   - Rotate secrets regularly (every 90 days recommended)
   - Use different credentials for development and production

2. **File Uploads**
   - Only authenticated users can upload
   - Files are stored in Cloudflare R2, not on the server
   - Public URLs are generated for uploaded files

3. **Database Access**
   - All database operations use Supabase SDK
   - RLS policies enforce user-level permissions
   - Anonymous users can read public content but cannot create/modify

4. **User Input**
   - All user input is automatically escaped by Svelte
   - Comment length limited to 1000 characters
   - Username validation with regex

## Reporting Security Issues

If you discover a security vulnerability, please email: **security@bagincoffee.com**

**Do NOT** create a public GitHub issue for security vulnerabilities.

## Security Best Practices for Developers

1. **Never log sensitive information**
   ```typescript
   // ❌ Bad
   console.error('Error:', error);

   // ✅ Good
   console.error('Error:', error.message);
   ```

2. **Always check authentication**
   ```typescript
   const session = await getSession();
   if (!session?.user) {
       return fail(401, { error: 'Unauthorized' });
   }
   ```

3. **Validate user input**
   ```typescript
   if (!content || content.trim().length === 0) {
       return fail(400, { error: 'Content is required' });
   }
   ```

4. **Use type-safe environment variables**
   ```typescript
   import { R2_ACCESS_KEY_ID } from '$env/static/private';
   // Never use process.env directly
   ```

## Recommended Security Headers

Add to `svelte.config.js` for production:

```javascript
{
    kit: {
        csp: {
            directives: {
                'default-src': ['self'],
                'img-src': ['self', 'https://*.supabase.co', 'https://*.r2.dev'],
                'script-src': ['self']
            }
        }
    }
}
```

## Security Checklist for Production

- [ ] Rotate all API keys and secrets
- [ ] Enable Supabase RLS policies
- [ ] Configure CORS properly
- [ ] Set up monitoring and logging
- [ ] Enable Cloudflare bot protection
- [ ] Configure rate limiting
- [ ] Set up automated backups
- [ ] Review and update dependencies (`npm audit`)
- [ ] Enable 2FA for all admin accounts
- [ ] Set up security alerts

## Updates

This security policy is reviewed quarterly. Last updated: 2025-01-29
