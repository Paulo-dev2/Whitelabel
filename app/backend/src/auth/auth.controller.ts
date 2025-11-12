import { Controller, Post, Body, HttpCode, HttpStatus, UsePipes, ValidationPipe } from '@nestjs/common';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { User } from '@prisma/client';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK) 
  @UsePipes(new ValidationPipe({ whitelist: true })) 
  async login(@Body() loginDto: LoginDto) {
    const userIsExists: User | null = await this.authService.searchUserByEmail(
      loginDto.email, 
    );

    if (!userIsExists) {
      throw new Error('User not found');
    }

    const user: User | any = await this.authService.validateUser(
      loginDto.email, 
      loginDto.password, 
      userIsExists.clientId
    );
    
    return this.authService.login(user);
  }
}