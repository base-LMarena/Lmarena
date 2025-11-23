import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

// ─────────────────────────────────
// 유틸: 랜덤 정수
function randomInt(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// 유틸: 최근 30일 랜덤 날짜
function randomDate(): Date {
  const now = new Date();
  const d = randomInt(0, 30);
  const h = randomInt(0, 23);
  const m = randomInt(0, 59);
  const date = new Date(now);
  date.setDate(date.getDate() - d);
  date.setHours(date.getHours() - h);
  date.setMinutes(date.getMinutes() - m);
  return date;
}

// ─────────────────────────────────
// 랜덤 텍스트 생성기
function randomText(words = 20): string {
  const pool = [
    "AI",
    "블록체인",
    "철학",
    "수학",
    "프로그래밍",
    "데이터",
    "창의성",
    "로직",
    "웹3",
    "기술",
    "미래",
    "분석",
    "과학",
    "자연어처리",
    "모델링",
    "알고리즘",
    "시스템",
    "해석",
  ];

  let arr: string[] = [];
  for (let i = 0; i < words; i++) {
    arr.push(pool[randomInt(0, pool.length - 1)]);
  }
  return arr.join(" ");
}

// 랜덤 제목 만들기
function randomTitle() {
  const templates = [
    "오늘의 기술 이슈: {x}",
    "초보자를 위한 {x} 가이드",
    "{x}란 무엇인가?",
    "{x} 깊게 이해하기",
    "{x} 완전 정복하기",
    "왜 {x}는 중요한가?",
  ];
  const subjectPool = [
    "AI",
    "타입스크립트",
    "머신러닝",
    "철학",
    "웹 개발",
    "블록체인",
    "운영체제",
  ];
  const tpl = templates[randomInt(0, templates.length - 1)];
  return tpl.replace("{x}", subjectPool[randomInt(0, subjectPool.length - 1)]);
}

// 랜덤 프롬프트
function randomPrompt() {
  return `다음 주제에 대해 설명해주세요: ${randomText(8)}.`;
}

// 랜덤 응답(간단한 마크다운)
function randomResponse() {
  return `# 랜덤 응답 생성\n\n${randomText(30)}.\n\n## 추가 설명\n${randomText(
    40
  )}.`;
}

// ─────────────────────────────────

async function main() {
  console.log("🌱 Starting seed...");

  // 1. 모델 생성
  await prisma.model.createMany({
    data: [
      {
        name: "Qwen 30B Instruct",
        provider: "flock",
        apiModelId: "qwen3-30b-a3b-instruct-2507",
      },
      {
        name: "Qwen 235B Thinking",
        provider: "flock",
        apiModelId: "qwen3-235b-a22b-thinking-2507",
      },
      {
        name: "Qwen 235B Instruct",
        provider: "flock",
        apiModelId: "qwen3-235b-a22b-instruct-2507",
      },
    ],
    skipDuplicates: true,
  });
  const modelList = await prisma.model.findMany();
  console.log("✅ Models seeded");

  // 2. 유저 150명 생성
  const users = [];
  for (let i = 0; i < 150; i++) {
    // 랜덤 지갑 주소 생성 (0x + 40자리 hex)
    const wallet = "0x" + Array.from({ length: 40 }, () => 
      Math.floor(Math.random() * 16).toString(16)
    ).join("");
    
    let user = await prisma.user.findFirst({ where: { nickname: wallet } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          nickname: wallet,
          createdAt: randomDate(),
        },
      });
    }
    users.push(user);
  }
  console.log(`✅ ${users.length} users seeded`);

  // 3. 태그
  const tagNames = [
    "AI",
    "코딩",
    "수학",
    "철학",
    "창작",
    "비즈니스",
    "과학",
    "일상",
  ];
  const tags = [];

  for (const t of tagNames) {
    let tag = await prisma.tag.findFirst({ where: { name: t } });
    if (!tag) {
      tag = await prisma.tag.create({
        data: { name: t },
      });
    }
    tags.push(tag);
  }
  console.log(`✅ ${tags.length} tags seeded`);

  // 4. 랜덤 포스트 15개 생성
  const POST_COUNT = 15;
  let createdCount = 0;

  for (let i = 0; i < POST_COUNT; i++) {
    const randomUser = users[randomInt(0, users.length - 1)];
    const randomModelA = modelList[randomInt(0, modelList.length - 1)];
    const randomModelB = modelList[randomInt(0, modelList.length - 1)];

    // Prompt
    const prompt = await prisma.prompt.create({
      data: { text: randomPrompt() },
    });

    // Match
    const match = await prisma.match.create({
      data: {
        promptId: prompt.id,
        modelAId: randomModelA.id,
        modelBId: randomModelB.id,
      },
    });

    // Response
    await prisma.response.create({
      data: {
        matchId: match.id,
        modelId: randomModelA.id,
        position: "A",
        content: randomResponse(),
      },
    });

    // Post
    const post = await prisma.post.create({
      data: {
        matchId: match.id,
        userId: randomUser.id,
        title: randomTitle(),
        likes: 0,
        createdAt: randomDate(),
      },
    });

    // 랜덤 태그 1~3개 선택
    const tagCount = randomInt(1, 3);
    const shuffled = [...tags].sort(() => Math.random() - 0.5);
    for (let t = 0; t < tagCount; t++) {
      await prisma.postTag.create({
        data: { postId: post.id, tagId: shuffled[t].id },
      });
    }

    // 좋아요 추가 (랜덤하게 여러 유저가 좋아요)
    const likeCount = randomInt(10, 200); // ✅ 10~200 사이 랜덤
    const likers = new Set<number>();

    // 유저 수보다 많이 누를 수는 없으니까 min 처리
    const targetLikeCount = Math.min(likeCount, users.length);

    while (likers.size < targetLikeCount) {
      const randomUserIdx = Math.floor(Math.random() * users.length);
      likers.add(randomUserIdx);
    }

    for (const userIdx of likers) {
      await prisma.postLike.create({
        data: {
          postId: post.id,
          userId: users[userIdx].id,
        },
      });
    }

    // Post의 likes 필드 업데이트
    await prisma.post.update({
      where: { id: post.id },
      data: { likes: likers.size }, // 실제로 생성된 좋아요 수 반영
    });

    createdCount++;
    console.log(`📝 Post ${createdCount}/${POST_COUNT} created`);
  }

  console.log(`🎉 ${createdCount} random posts created!`);
}

main()
  .catch((e) => {
    console.error("❌ Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
