import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Client } from '@prisma/client';

@Injectable()
export class ClientRepository {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Busca um cliente pelo seu hostUrl (domínio Whitelabel)
   */
  async findByHostUrl(hostUrl: string): Promise<Client> {
    const client = await this.prisma.client.findUnique({
      where: {
        hostUrl: hostUrl,
      },
    });

    if (!client) {
      throw new NotFoundException(`Client with host URL "${hostUrl}" not found.`);
    }

    return client;
  }
}