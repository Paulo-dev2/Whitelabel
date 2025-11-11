import { Controller, Get, Query, HttpException, HttpStatus } from '@nestjs/common';
import { ClientService } from './client.service';
import { Client } from '@prisma/client';

@Controller('clients')
export class ClientController {
  constructor(private readonly clientService: ClientService) {}
  @Get('config')
  async getClientConfig(@Query('host') hostUrl: string): Promise<Client> {
    if (!hostUrl) {
      throw new HttpException('Host URL query parameter is required.', HttpStatus.BAD_REQUEST);
    }
    return this.clientService.getClientConfigByHost(hostUrl);
  }
}