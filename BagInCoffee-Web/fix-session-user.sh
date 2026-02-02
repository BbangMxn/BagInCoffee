#!/bin/bash

# 모든 API 파일에서 session.user를 getUser()로 변경하는 스크립트

FILES=(
  "src/routes/api/posts/+server.ts"
  "src/routes/api/upload/avatar/+server.ts"
  "src/routes/api/upload/post-images/+server.ts"
  "src/routes/api/equipment/+server.ts"
  "src/routes/api/guide/[id]/+server.ts"
  "src/routes/api/guide/+server.ts"
  "src/routes/api/notifications/mark-read/+server.ts"
  "src/routes/api/notifications/unread-count/+server.ts"
  "src/routes/api/notifications/+server.ts"
  "src/routes/api/marketplace/[id]/+server.ts"
  "src/routes/api/marketplace/+server.ts"
  "src/routes/api/recipes/[id]/+server.ts"
  "src/routes/api/recipes/+server.ts"
  "src/routes/api/equipment/[id]/reviews/+server.ts"
  "src/routes/api/equipment/[id]/+server.ts"
  "src/routes/api/posts/[id]/comments/+server.ts"
  "src/routes/api/posts/[id]/like/+server.ts"
  "src/routes/api/posts/[id]/+server.ts"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "수정 중: $file"

    # 1. locals에서 safeGetSession 또는 getSession 제거하고 supabase만 남기기
    sed -i 's/locals: { supabase, safeGetSession }/locals: { supabase }/g' "$file"
    sed -i 's/locals: { supabase, getSession }/locals: { supabase }/g' "$file"
    sed -i 's/locals: { getSession, supabase }/locals: { supabase }/g' "$file"
    sed -i 's/locals: { safeGetSession, supabase }/locals: { supabase }/g' "$file"

    # 2. safeGetSession() 호출을 getUser()로 변경
    sed -i 's/const { session } = await safeGetSession();/const { data: { user } } = await supabase.auth.getUser();/g' "$file"
    sed -i 's/const { session, user } = await safeGetSession();/const { data: { user } } = await supabase.auth.getUser();/g' "$file"
    sed -i 's/const session = await getSession();/const { data: { user } } = await supabase.auth.getUser();/g' "$file"
    sed -i 's/const session = await safeGetSession();/const { data: { user } } = await supabase.auth.getUser();/g' "$file"

    # 3. session?.user 체크를 user 체크로 변경
    sed -i 's/if (!session?.user)/if (!user)/g' "$file"
    sed -i 's/if (!session)/if (!user)/g' "$file"
    sed -i 's/if (session?.user)/if (user)/g' "$file"
    sed -i 's/if (session)/if (user)/g' "$file"

    # 4. session.user.id를 user.id로 변경
    sed -i 's/session\.user\.id/user.id/g' "$file"
    sed -i 's/session\.user/user/g' "$file"

    echo "✅ 완료: $file"
  else
    echo "⚠️  파일 없음: $file"
  fi
done

echo ""
echo "✅ 모든 API 파일 수정 완료!"
