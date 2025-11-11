export interface AggregatedProduct {
  id: string; 
  title: string;
  description: string;
  price: number;
  provider: 'brazilian' | 'european'; // Identifica a origem
  image?: string;
}