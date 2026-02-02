// 디자인 시스템 - 테마 설정
export const theme = {
	// 메인 컬러 (연브라운)
	colors: {
		primary: {
			50: '#fdf8f6',
			100: '#f2e8e5',
			200: '#eaddd7',
			300: '#e0cec7',
			400: '#d2bab0',
			500: '#bfa094',  // 메인 컬러
			600: '#a18072',
			700: '#7f6251',
			800: '#5d4a3f',
			900: '#3e312b',
		},
		// 악센트 컬러
		accent: {
			light: '#d4a574',  // 밝은 브라운
			main: '#b8936c',   // 중간 브라운
			dark: '#8b6f47',   // 진한 브라운
		},
		// 시스템 컬러
		success: '#10b981',
		warning: '#f59e0b',
		error: '#ef4444',
		info: '#3b82f6',

		// 그레이 스케일
		gray: {
			50: '#f9fafb',
			100: '#f3f4f6',
			200: '#e5e7eb',
			300: '#d1d5db',
			400: '#9ca3af',
			500: '#6b7280',
			600: '#4b5563',
			700: '#374151',
			800: '#1f2937',
			900: '#111827',
		}
	},

	// 공통 사용 색상 (자주 사용되는 색상 상수)
	common: {
		// 아이콘 색상
		icon: {
			primary: '#bfa094',      // 메인 아이콘
			secondary: '#7f6251',    // 보조 아이콘
			muted: '#9ca3af',        // 비활성 아이콘
			dark: '#5d4a3f',         // 진한 아이콘
		},
		// 텍스트 색상
		text: {
			primary: '#5d4a3f',      // 메인 텍스트
			secondary: '#7f6251',    // 보조 텍스트
			muted: '#9ca3af',        // 비활성 텍스트
			light: '#6b7280',        // 밝은 텍스트
		},
		// 배경 색상
		bg: {
			primary: '#ffffff',      // 메인 배경
			secondary: '#fdf8f6',    // 보조 배경
			muted: '#f9fafb',        // 비활성 배경
			accent: '#f2e8e5',       // 악센트 배경
			hover: '#eaddd7',        // 호버 배경
		},
		// 보더 색상
		border: {
			light: '#f3f4f6',        // 밝은 보더
			default: '#e5e7eb',      // 기본 보더
			dark: '#d1d5db',         // 진한 보더
		},
	},

	// 브랜드 정보
	brand: {
		name: 'BagInCoffee',
		tagline: '당신의 커피, 우리의 이야기',
	},

	// 레이아웃 설정
	layout: {
		header: {
			height: '56px',
			heightClass: 'h-14',
		},
		bottomNav: {
			height: '64px',
			heightClass: 'h-16',
		},
		sidebar: {
			width: '320px',
			widthClass: 'w-80',
		},
	},

	// 애니메이션 설정
	animation: {
		duration: {
			fast: '150ms',
			normal: '300ms',
			slow: '500ms',
		},
	},
} as const;

// Tailwind CSS 클래스 헬퍼 (공통 색상 사용)
export const tw = {
	// 텍스트
	text: {
		primary: 'text-[#5d4a3f]',           // theme.common.text.primary
		secondary: 'text-[#7f6251]',         // theme.common.text.secondary
		muted: 'text-[#9ca3af]',             // theme.common.text.muted
		light: 'text-[#6b7280]',             // theme.common.text.light
	},

	// 아이콘
	icon: {
		primary: 'text-[#bfa094]',           // theme.common.icon.primary
		secondary: 'text-[#7f6251]',         // theme.common.icon.secondary
		muted: 'text-[#9ca3af]',             // theme.common.icon.muted
		dark: 'text-[#5d4a3f]',              // theme.common.icon.dark
	},

	// 배경
	bg: {
		primary: 'bg-white',                 // theme.common.bg.primary
		secondary: 'bg-[#fdf8f6]',           // theme.common.bg.secondary
		accent: 'bg-[#f2e8e5]',              // theme.common.bg.accent
		hover: 'hover:bg-[#eaddd7]',         // theme.common.bg.hover
	},

	// 보더
	border: {
		light: 'border-[#f3f4f6]',           // theme.common.border.light
		default: 'border-[#e5e7eb]',         // theme.common.border.default
		dark: 'border-[#d1d5db]',            // theme.common.border.dark
	},

	// 메인 버튼
	button: {
		primary: 'bg-[#bfa094] hover:bg-[#a18072] active:bg-[#7f6251] text-white font-medium rounded-lg transition-colors',
		secondary: 'bg-[#f2e8e5] hover:bg-[#eaddd7] active:bg-[#e0cec7] text-[#5d4a3f] font-medium rounded-lg transition-colors',
		outline: 'border-2 border-[#bfa094] text-[#bfa094] hover:bg-[#bfa094] hover:text-white font-medium rounded-lg transition-colors',
	},

	// 카드
	card: {
		base: 'bg-white rounded-xl shadow-sm border border-[#e5e7eb]',
		hover: 'bg-white rounded-xl shadow-sm border border-[#e5e7eb] hover:shadow-md transition-shadow',
		interactive: 'bg-white rounded-xl shadow-sm border border-[#e5e7eb] active:scale-95 transition-transform',
	},

	// 링크
	link: {
		primary: 'text-[#bfa094] hover:text-[#a18072] font-medium transition-colors',
		secondary: 'text-[#7f6251] hover:text-[#5d4a3f] transition-colors',
	},

	// 배지
	badge: {
		primary: 'bg-[#f2e8e5] text-[#7f6251] text-xs font-bold px-2 py-0.5 rounded-full',
		success: 'bg-green-100 text-green-800 text-xs font-bold px-2 py-0.5 rounded-full',
		warning: 'bg-yellow-100 text-yellow-800 text-xs font-bold px-2 py-0.5 rounded-full',
		error: 'bg-red-100 text-red-800 text-xs font-bold px-2 py-0.5 rounded-full',
		info: 'bg-blue-100 text-blue-800 text-xs font-bold px-2 py-0.5 rounded-full',
	},

	// 아이콘 컨테이너
	iconBox: {
		primary: 'w-12 h-12 bg-[#f2e8e5] rounded-full flex items-center justify-center',
		success: 'w-12 h-12 bg-green-100 rounded-full flex items-center justify-center',
		warning: 'w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center',
		error: 'w-12 h-12 bg-red-100 rounded-full flex items-center justify-center',
		info: 'w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center',
	},

	// 메뉴 아이템
	menuItem: {
		base: 'flex items-center space-x-3 px-3 py-3 text-[#5d4a3f] hover:bg-[#f2e8e5] hover:text-[#7f6251] rounded-lg transition-colors active:bg-[#eaddd7]',
	},
} as const;
