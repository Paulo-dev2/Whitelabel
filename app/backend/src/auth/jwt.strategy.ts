import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable } from '@nestjs/common';

export interface JwtPayload {
  email: string;
  sub: number; 
  clientId: number; 
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false, 
      secretOrKey: process.env.JWT_SECRET || 'YOUR_SECURE_SECRET_KEY',
    });
  }

  async validate(payload: JwtPayload): Promise<JwtPayload> {
    return payload; 
  }
}