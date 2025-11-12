import { Controller, Get, Headers, Query, HttpException, HttpStatus } from '@nestjs/common';
import { ClientService } from './client.service';
import { Client } from '@prisma/client';

@Controller('clients')
export class ClientController {
  constructor(private readonly clientService: ClientService) {}

  @Get('config')
  async getClientConfig(
    @Headers('host') hostHeader: string,
    @Headers('domain') domainQuery: string
  ): Promise<Client> {
    
    let hostToUse: string | undefined; 

    if (domainQuery) {
      hostToUse = domainQuery;
    }

    console.log('Host Header:', hostHeader);
    console.log('Domain Query:', domainQuery);

    if (!hostToUse || hostToUse.length === 0) {
      throw new HttpException('Host information is missing or invalid.', HttpStatus.BAD_REQUEST);
    }

    return this.clientService.getClientConfigByHost(hostToUse);
  }
}