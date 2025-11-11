import { Controller, Get, Headers, HttpException, HttpStatus } from '@nestjs/common';
import { ClientService } from './client.service';
import { Client } from '@prisma/client';

@Controller('clients')
export class ClientController {
  constructor(private readonly clientService: ClientService) {}

  @Get('config')
  async getClientConfig(@Headers('host') hostHeader: string): Promise<Client> {
    if (!hostHeader) {
      throw new HttpException('Host header is missing.', HttpStatus.BAD_REQUEST);
    }
    const hostUrl = hostHeader.split(':')[0];
    return this.clientService.getClientConfigByHost(hostUrl);
  }
}