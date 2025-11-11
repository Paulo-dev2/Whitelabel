import { PrismaClient, Prisma } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();
const rounds = 10; 

async function main() {
  console.log(`\n--- Start seeding ---`);

  await prisma.user.deleteMany({});
  await prisma.client.deleteMany({});
  console.log('Dados anteriores limpos.');

  const clientData: Prisma.ClientCreateInput[] = [
    {
      name: 'Loja Alpha',
      hostUrl: 'alpha.local',
      themeConfig: {
        primaryColor: '#007bff',
        logoUrl: 'https://placehold.co/150x50/007bff/white?text=Alpha',
      },
    },
    {
      name: 'Loja Beta',
      hostUrl: 'beta.local',
      themeConfig: {
        primaryColor: '#dc3545',
        logoUrl: 'https://placehold.co/150x50/dc3545/white?text=Beta',
      },
    },
  ];

  const clients = await Promise.all(
    clientData.map(data => prisma.client.create({ data })),
  );

  console.log(`Criados ${clients.length} clientes.`);

  const hashedPassword = await bcrypt.hash('123456', rounds);

  const userData: Prisma.UserCreateInput[] = [
    {
      name: 'Alpha Admin',
      email: 'admin.alpha@teste.com',
      passwordHash: hashedPassword,
      client: { connect: { id: clients[0].id } },
    },
    {
      name: 'Beta Admin',
      email: 'admin.beta@teste.com',
      passwordHash: hashedPassword,
      client: { connect: { id: clients[1].id } },
    },
  ];

  await Promise.all(userData.map(data => prisma.user.create({ data })));

  console.log(`Criados ${userData.length} usuários.`);
  console.log(`--- Seeding finalizado ---`);
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });