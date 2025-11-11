import { Injectable } from '@nestjs/common';
import { ClientRepository } from './client.repository';
import { Client } from '@prisma/client';

@Injectable()
export class ClientService {
    constructor(private readonly clientRepository: ClientRepository) {}

    async getClientConfigByHost(hostUrl: string): Promise<Client> {
        const client = await this.clientRepository.findByHostUrl(hostUrl);
        
        return client;
    }
}
