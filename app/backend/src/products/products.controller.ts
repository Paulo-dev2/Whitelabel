import { Controller, Get, UseGuards, Req, Param } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ProductsService } from './products.service'; 
import { JwtPayload } from '../auth/jwt.strategy'; 

@Controller('products')
@UseGuards(AuthGuard('jwt')) 
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}
 @Get()
  async getProducts(@Req() req) {
    const userPayload: JwtPayload = req.user;
    
    console.log(`Fetching products for Client ID: ${userPayload.clientId}`); 

    const products = await this.productsService.findAll();
        
    return {
        count: products.length,
        clientId: userPayload.clientId,
        data: products
    };
  }

  @Get(':id')
  async getProductById(@Param('id') id: string, @Req() req) {
    const userPayload: JwtPayload = req.user;
    
    const product = await this.productsService.findById(id);

    return {
        clientId: userPayload.clientId,
        data: product
    };
  }
}