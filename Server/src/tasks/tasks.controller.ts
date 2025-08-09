import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Param, 
  Patch, 
  Delete,
  NotFoundException 
} from '@nestjs/common';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';

@Controller('tasks')
export class TasksController {
  constructor(private readonly tasksService: TasksService) {}

  @Get()
  async findAll() {
    return this.tasksService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    try {
      return await this.tasksService.findOne(+id);
    } catch (error) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }
  }

  @Post()
  async create(@Body() createTaskDto: CreateTaskDto) {
    return this.tasksService.create(createTaskDto);
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateTaskDto: UpdateTaskDto) {
    try {
      return await this.tasksService.update(+id, updateTaskDto);
    } catch (error) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }
  }

@Delete(':id')
async remove(@Param('id') id: string) {
  await this.tasksService.remove(+id);
  return { message: 'Task deleted successfully' };
}
}