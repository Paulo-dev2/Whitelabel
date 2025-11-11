import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { AggregatedProduct } from './interfaces/product.interface';
import { catchError, map, firstValueFrom } from 'rxjs';

const BRAZILIAN_PROVIDER_URL = 'http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/brazilian_provider';
const EUROPEAN_PROVIDER_URL = 'http://616d6bdb6dacbb001794ca17.mockapi.io/devnology/european_provider';

@Injectable()
export class ProductsService {
  constructor(private readonly httpService: HttpService) {}

  private mapBrazilianProduct(product: any): AggregatedProduct {
    return {
      id: `br-${product.id}`,
      title: product.name,
      description: product.description,
      price: product.price,
      provider: 'brazilian',
      image: product.image,
    };
  }

  private mapEuropeanProduct(product: any): AggregatedProduct {
    return {
      id: `eu-${product.id}`,
      title: product.name, 
      description: product.description,
      price: product.price,
      provider: 'european',
      image: product.image,
    };
  }

  async findAll(): Promise<AggregatedProduct[]> {
    const brazilianProductsPromise = firstValueFrom(
      this.httpService.get(BRAZILIAN_PROVIDER_URL).pipe(
        map(response => response.data.map(this.mapBrazilianProduct)),
        catchError((error) => {
          console.error('Brazilian provider failed:', error.message);
          return []; 
        }),
      ),
    );

    const europeanProductsPromise = firstValueFrom(
      this.httpService.get(EUROPEAN_PROVIDER_URL).pipe(
        map(response => response.data.map(this.mapEuropeanProduct)),
        catchError((error) => {
          console.error('European provider failed:', error.message);
          return [];
        }),
      ),
    );

    try {
      const [brazilianProducts, europeanProducts] = await Promise.all([
        brazilianProductsPromise,
        europeanProductsPromise,
      ]);

      return [...brazilianProducts, ...europeanProducts];
      
    } catch (error) {
      throw new InternalServerErrorException('Failed to aggregate products from external providers.');
    }
  }
}