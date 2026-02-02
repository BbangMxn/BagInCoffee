import adapter from '@sveltejs/adapter-vercel';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: vitePreprocess(),

	kit: {
		adapter: adapter({
			// Vercel deployment configuration
			runtime: 'nodejs20.x',
			regions: ['icn1'], // Seoul region for better performance
			maxDuration: 10
		})
	}
};

export default config;
