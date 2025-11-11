import { Controller, Get, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Controller('products')
@UseGuards(AuthGuard('jwt')) 
export class ProductsController {
  @Get()
  getProducts(@Req() req) {
    const clientId = req.user.clientId; 
    
    return { 
        message: `Products list for Client ID: ${clientId}`,
        data: [{ id: 1, name: 'Sample Product' }] 
    };
  }
}