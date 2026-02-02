import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [sveltekit()],

	// 개발 서버 최적화
	server: {
		fs: {
			// 파일 시스템 접근 최적화
			strict: true
		},
		// HMR 성능 향상
		hmr: {
			overlay: false
		}
	},

	// 빌드 최적화
	build: {
		// 소스맵 비활성화로 빌드 속도 향상
		sourcemap: false,
		// 청크 사이즈 경고 한계 증가
		chunkSizeWarningLimit: 1000,
		// CSS 코드 스플릿 활성화
		cssCodeSplit: true,
		// minify 옵션 최적화
		minify: 'esbuild',
		// 롤업 옵션
		rollupOptions: {
			output: {
				// 수동 청크 분할로 로딩 성능 향상
				manualChunks: (id) => {
					// node_modules를 vendor 청크로 분리
					if (id.includes('node_modules')) {
						// Supabase 관련 라이브러리 분리
						if (id.includes('@supabase')) {
							return 'vendor-supabase';
						}
						// AWS SDK 분리
						if (id.includes('@aws-sdk')) {
							return 'vendor-aws';
						}
						// Marked (markdown) 분리
						if (id.includes('marked')) {
							return 'vendor-marked';
						}
						// 나머지 vendor
						return 'vendor';
					}
				}
			}
		}
	},

	// 의존성 사전 최적화 (개발 서버 시작 속도 향상)
	optimizeDeps: {
		include: [
			'@supabase/supabase-js',
			'@supabase/ssr',
			'marked'
		],
		// 의존성 스캔 제외 (불필요한 파일 스캔 방지)
		exclude: ['@aws-sdk/client-s3'],
		// ESBuild 옵션
		esbuildOptions: {
			target: 'es2020'
		}
	},

	// CSS 성능 최적화
	css: {
		devSourcemap: false
	},

	// 캐싱 전략
	cacheDir: 'node_modules/.vite'
});
