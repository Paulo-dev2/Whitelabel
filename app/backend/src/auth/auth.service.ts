import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UserService } from '../user/user.service';
import * as bcrypt from 'bcrypt';
import { User } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  async searchUserByEmail(email: string): Promise<User | null> {
    try {
      // Busca o usuário pelo email
      const user = await this.userService.findByEmail(email);
      if (user) {
        const { passwordHash, ...result } = user;
        return result as User;
      }
      return null;
    } catch (error) {
      throw new UnauthorizedException('User not found or does not belong to the specified client.');
    }
  }

  async validateUser(email: string, pass: string, clientId: number): Promise<User | null> {
    try {
      // 1. Busca o usuário pelo email e clientId (aqui o Whitelabel é aplicado!)
      const user = await this.userService.findUserForLogin(email, clientId);

      // 2. Compara a senha fornecida com o hash armazenado
      const isMatch = await bcrypt.compare(pass, user.passwordHash);

      if (isMatch) {
        // Se a senha for válida, remove o hash da senha antes de retornar
        const { passwordHash, ...result } = user;
        return result as User;
      }
      return null;
    } catch (error) {
      throw new UnauthorizedException('Invalid credentials or client.');
    }
  }

  async login(user: User) {
    const payload = { 
      email: user.email, 
      sub: user.id, 
      clientId: user.clientId 
    };

    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}