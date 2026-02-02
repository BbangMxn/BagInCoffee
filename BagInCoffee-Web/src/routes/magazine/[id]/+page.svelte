<script lang="ts">
	import { page } from '$app/stores';

	// Get article ID from URL
	const articleId = $derived($page.params.id);

	// Mock article data - in real app, fetch from API/database
	const article = $derived({
		id: articleId,
		category: 'Feature',
		title: 'The New Wave of Coffee',
		subtitle: '2025년을 이끌어갈 커피 트렌드를 미리 만나보세요',
		author: 'Min-ji Kim',
		authorTitle: 'Senior Editor',
		date: 'January 15, 2025',
		readTime: '8 min read',
		content: `
			커피 산업은 끊임없이 진화하고 있습니다. 2025년, 우리는 지속가능성과 혁신이 만나는 새로운 시대를 맞이하고 있습니다.

			## 지속가능한 로스팅의 시대

			현대의 로스터들은 단순히 맛있는 커피를 만드는 것을 넘어, 환경에 미치는 영향을 최소화하는 방법을 모색하고 있습니다. 전기 로스터, 태양광 에너지 활용, 그리고 탄소 중립 로스팅은 이제 선택이 아닌 필수가 되어가고 있습니다.

			많은 로스터리들이 탄소 발자국을 줄이기 위해 노력하고 있으며, 일부는 이미 100% 재생 에너지로 운영되고 있습니다. 이러한 변화는 소비자들의 의식 있는 선택과 맞물려 더욱 가속화되고 있습니다.

			## 새로운 추출 방식의 등장

			전통적인 에스프레소와 드립 커피를 넘어, 새로운 추출 방식들이 주목받고 있습니다. 저온 추출, 초고압 추출, 그리고 발효 기법을 활용한 추출 방식들이 바리스타들 사이에서 실험되고 있습니다.

			특히 일본에서 시작된 '워터 드립' 방식은 전 세계적으로 인기를 얻고 있으며, 각 나라의 문화적 특성이 반영된 독특한 추출 방법들이 계속해서 개발되고 있습니다.

			## 스페셜티 커피의 대중화

			한때 소수의 애호가들만 즐기던 스페셜티 커피가 이제는 일상이 되어가고 있습니다. 편의점에서도 싱글 오리진 커피를 만날 수 있게 되었고, 대형 체인 카페들도 스페셜티 라인을 확대하고 있습니다.

			이러한 변화는 소비자들의 커피에 대한 이해도가 높아졌음을 의미하며, 동시에 품질 좋은 커피에 대한 접근성이 크게 개선되었음을 보여줍니다.

			## 기술과 전통의 조화

			AI를 활용한 로스팅 프로파일 최적화, 블록체인을 통한 원두 이력 추적, IoT 기반 추출 관리 시스템 등 첨단 기술이 커피 산업에 도입되고 있습니다.

			하지만 이러한 기술의 발전 속에서도 수작업의 가치, 장인 정신, 그리고 커피 본연의 맛을 중요시하는 움직임도 함께 존재합니다. 결국 기술은 더 나은 커피를 만들기 위한 도구일 뿐, 핵심은 여전히 사람과 커피의 관계입니다.

			## 결론

			2025년 커피 트렌드는 단순히 유행을 따르는 것이 아니라, 더 나은 미래를 위한 진지한 고민의 결과입니다. 환경을 생각하고, 품질을 추구하며, 기술을 활용하되 본질을 잃지 않는 것. 이것이 우리가 나아갈 방향입니다.
		`
	});
</script>

<!-- Fashion Magazine Article Detail -->
<article class="min-h-screen bg-white">
	<!-- Header -->
	<div class="border-b border-[#e5e7eb]">
		<div class="max-w-4xl mx-auto px-6 py-6">
			<a href="/magazine" class="inline-flex items-center gap-2 text-xs text-[#9ca3af] uppercase tracking-[0.2em] hover:text-[#5d4a3f] transition-colors">
				<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
				</svg>
				Back to Magazine
			</a>
		</div>
	</div>

	<!-- Hero Section -->
	<div class="max-w-4xl mx-auto px-6 py-12">
		<!-- Category & Metadata -->
		<div class="flex items-center gap-4 mb-8">
			<span class="text-[10px] text-[#bfa094] uppercase tracking-[0.3em]">{article.category}</span>
			<span class="text-[10px] text-[#9ca3af]">•</span>
			<span class="text-[10px] text-[#9ca3af] uppercase tracking-[0.2em]">{article.readTime}</span>
		</div>

		<!-- Title -->
		<h1 class="text-5xl md:text-6xl font-light text-[#5d4a3f] mb-6 leading-[1.1] tracking-tight">
			{article.title}
		</h1>

		<!-- Subtitle -->
		<p class="text-xl text-[#7f6251] font-light mb-12 leading-relaxed">
			{article.subtitle}
		</p>

		<!-- Author Info -->
		<div class="flex items-center gap-4 pb-12 border-b border-[#e5e7eb]">
			<div class="w-12 h-12 rounded-full bg-[#f2e8e5]"></div>
			<div>
				<p class="text-sm text-[#5d4a3f] font-medium">{article.author}</p>
				<p class="text-xs text-[#9ca3af] uppercase tracking-wider">{article.authorTitle}</p>
			</div>
			<div class="ml-auto text-right">
				<p class="text-xs text-[#9ca3af] uppercase tracking-[0.2em]">{article.date}</p>
			</div>
		</div>
	</div>

	<!-- Featured Image -->
	<div class="max-w-6xl mx-auto px-6 mb-16">
		<div class="aspect-[16/9] bg-gradient-to-br from-[#d2bab0]/30 to-[#bfa094]/50 relative">
			<div class="absolute inset-0 flex items-center justify-center">
				<div class="text-white/10 text-8xl font-light tracking-widest">2025</div>
			</div>
		</div>
	</div>

	<!-- Article Content -->
	<div class="max-w-3xl mx-auto px-6 pb-20">
		<div class="prose prose-lg max-w-none">
			{#each article.content.split('\n\n') as paragraph}
				{#if paragraph.trim().startsWith('##')}
					<h2 class="text-3xl font-light text-[#5d4a3f] mt-16 mb-6 tracking-tight">
						{paragraph.replace('##', '').trim()}
					</h2>
				{:else if paragraph.trim()}
					<p class="text-base text-[#5d4a3f] leading-relaxed mb-6 font-light">
						{paragraph.trim()}
					</p>
				{/if}
			{/each}
		</div>

		<!-- Share Section -->
		<div class="mt-16 pt-12 border-t border-[#e5e7eb]">
			<div class="text-center">
				<p class="text-xs text-[#9ca3af] uppercase tracking-[0.3em] mb-6">Share this story</p>
				<div class="flex items-center justify-center gap-6">
					<button class="w-10 h-10 rounded-full border border-[#e5e7eb] flex items-center justify-center text-[#7f6251] hover:bg-[#f2e8e5] hover:border-[#bfa094] transition-colors">
						<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
							<path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
						</svg>
					</button>
					<button class="w-10 h-10 rounded-full border border-[#e5e7eb] flex items-center justify-center text-[#7f6251] hover:bg-[#f2e8e5] hover:border-[#bfa094] transition-colors">
						<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
							<path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
						</svg>
					</button>
					<button class="w-10 h-10 rounded-full border border-[#e5e7eb] flex items-center justify-center text-[#7f6251] hover:bg-[#f2e8e5] hover:border-[#bfa094] transition-colors">
						<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
							<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
						</svg>
					</button>
				</div>
			</div>
		</div>

		<!-- Related Articles -->
		<div class="mt-20 pt-16 border-t border-[#e5e7eb]">
			<div class="mb-12">
				<h3 class="text-3xl font-light text-[#5d4a3f] tracking-wide">You May Also Like</h3>
				<div class="w-16 h-[1px] bg-[#5d4a3f] mt-3"></div>
			</div>

			<div class="grid md:grid-cols-2 gap-12">
				<!-- Related Article 1 -->
				<a href="/magazine/2" class="group">
					<div class="aspect-[4/3] bg-[#f5f5f0] mb-4 relative overflow-hidden">
						<div class="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
					</div>
					<div class="text-[10px] text-[#bfa094] uppercase tracking-[0.2em] mb-2">Interview</div>
					<h4 class="text-xl font-light text-[#5d4a3f] mb-2 leading-tight group-hover:text-[#bfa094] transition-colors">
						Champion's Secret
					</h4>
					<p class="text-xs text-[#7f6251] leading-relaxed font-light">
						2024 바리스타 챔피언이 말하는 완벽한 한 잔
					</p>
				</a>

				<!-- Related Article 2 -->
				<a href="/magazine/3" class="group">
					<div class="aspect-[4/3] bg-[#ebe8e3] mb-4 relative overflow-hidden">
						<div class="absolute inset-0 bg-black/5 opacity-0 group-hover:opacity-100 transition-opacity"></div>
					</div>
					<div class="text-[10px] text-[#bfa094] uppercase tracking-[0.2em] mb-2">Review</div>
					<h4 class="text-xl font-light text-[#5d4a3f] mb-2 leading-tight group-hover:text-[#bfa094] transition-colors">
						Grinder Guide 2025
					</h4>
					<p class="text-xs text-[#7f6251] leading-relaxed font-light">
						프리미엄 그라인더 5종 심층 비교 분석
					</p>
				</a>
			</div>
		</div>
	</div>

	<!-- Footer Quote -->
	<div class="border-t border-[#e5e7eb]">
		<div class="max-w-4xl mx-auto px-6 py-16 text-center">
			<blockquote class="text-2xl font-light text-[#5d4a3f] italic leading-relaxed">
				"Every cup tells a story"
			</blockquote>
			<p class="text-xs text-[#9ca3af] uppercase tracking-[0.3em] mt-6">Bag in Coffee</p>
		</div>
	</div>
</article>
