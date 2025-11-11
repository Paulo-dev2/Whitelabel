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
    
    const user: User | any = await this.authService.validateUser(
      loginDto.email, 
      loginDto.password, 
      loginDto.clientId
    );
    
    return this.authService.login(user);
  }
}