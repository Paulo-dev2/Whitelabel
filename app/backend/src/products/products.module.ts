import { Module } from '@nestjs/common';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { HttpModule } from '@nestjs/axios'; 

@Module({
  imports: [
    HttpModule.register({
      timeout: 5000, 
      maxRedirects: 5,
    }),
  ],
  controllers: [ProductsController],
  providers: [ProductsService],
})
export class ProductsModule {}