import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { User } from '@prisma/client';

@Injectable()
export class UserRepository {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Busca um usuário pelo email E pela ID do cliente.
   * Isso garante que um usuário da Loja Alpha não possa logar na Loja Beta.
   */
  async findByEmailAndClientId(email: string, clientId: number): Promise<User> {
    const user = await this.prisma.user.findFirst({
      where: { email, clientId },
      include: { client: true },
    });
    if (!user) {
      throw new NotFoundException('Invalid credentials.');
    }
    return user;
  }
}