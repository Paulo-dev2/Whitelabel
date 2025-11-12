import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
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
      title: product.nome,
      description: product.descricao,
      price: product.preco,
      provider: 'brazilian',
      image: product.imagem,
    };
  }

  private mapEuropeanProduct(product: any): AggregatedProduct {
    return {
      id: `eu-${product.id}`,
      title: product.name, 
      description: product.description,
      price: product.price,
      provider: 'european',
      image: product.gallery,
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

  async findById(id: string): Promise<AggregatedProduct> {
    const brazilianUrl = `${BRAZILIAN_PROVIDER_URL}/${id}`;
    const europeanUrl = `${EUROPEAN_PROVIDER_URL}/${id}`;

    const promises = [
      this.fetchProductFromProvider(brazilianUrl, this.mapBrazilianProduct, 'Brazilian'),
      this.fetchProductFromProvider(europeanUrl, this.mapEuropeanProduct, 'European'),
    ];

    const results = await Promise.all(promises);

    const product = results.find(p => p !== null);

    if (!product) {
      throw new NotFoundException(`Product with ID "${id}" not found in any provider.`);
    }

    return product;
  }

  private async fetchProductFromProvider(
    url: string,
    mapper: (data: any) => AggregatedProduct,
    providerName: string,
  ): Promise<AggregatedProduct | null> {
    try {
      const response = await firstValueFrom(this.httpService.get(url));
      return mapper(response.data);
    } catch (error) {
      if (error.response && error.response.status === 404) {
        return null;
      }
      console.error(`Error fetching from ${providerName} provider: ${error.message}`);
      return null;
    }
  }
}