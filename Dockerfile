# 1단계: Dependencies 설치 (build용)
FROM node:18-alpine AS deps
WORKDIR /app

# package.json과 lock 파일만 복사해서 의존성 먼저 설치
COPY package.json package-lock.json* pnpm-lock.yaml* ./
RUN npm install --frozen-lockfile

# 2단계: Next.js 앱 빌드
FROM node:18-alpine AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# 3단계: 런타임 이미지 (작고 가벼움)
FROM node:18-alpine AS runner
WORKDIR /app

# 필수 파일만 복사
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

ENV NODE_ENV=production

# 포트 설정 (Next.js 기본 포트는 3000)
EXPOSE 3000

CMD ["npm", "start"]
