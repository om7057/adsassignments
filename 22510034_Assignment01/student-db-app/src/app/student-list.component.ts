import { Component } from '@angular/core';
import { NgFor, NgIf } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { StudentService } from './services/student.service';
import { HttpClient } from '@angular/common/http';

interface Student {
  id: number;
  name: string;
  age: number;
  department: string;
}

@Component({
  selector: 'app-student-list',
  standalone: true,
  imports: [NgFor, NgIf, FormsModule],  
  templateUrl: './student-list.component.html',
  styleUrls: ['./student-list.component.css'],
})
export class StudentListComponent {
  students: Student[] = [];
  newStudentName: string = '';
  newStudentAge: number | null = null;
  newStudentDepartment: string = '';

  constructor(private studentService: StudentService, private http: HttpClient) {}

  ngOnInit() {
    this.loadStudents();
  }

  loadStudents() {
    this.studentService.getStudents().subscribe(
      (data) => (this.students = data),
      (error) => console.error('Error fetching students:', error)
    );
  }

  addStudent() {
    if (!this.newStudentName || !this.newStudentAge || !this.newStudentDepartment) {
      alert('Please fill all fields!');
      return;
    }

    const newStudent = {
      name: this.newStudentName,
      age: this.newStudentAge,
      department: this.newStudentDepartment,
    };

    this.http.post('http://localhost:5000/students', newStudent).subscribe(
      () => {
        this.loadStudents();  // Refresh list
        this.newStudentName = '';
        this.newStudentAge = null;
        this.newStudentDepartment = '';
      },
      (error) => console.error('Error adding student:', error)
    );
  }

  updateStudent(id: number, student: Student) {
    const newName = prompt('Enter new name:', student.name);
    const newAge = prompt('Enter new age:', student.age.toString());
    const newDepartment = prompt('Enter new department:', student.department);

    if (newName && newAge && newDepartment) {
      const updatedStudent = { ...student, name: newName, age: parseInt(newAge), department: newDepartment };

      this.studentService.updateStudent(id, updatedStudent).subscribe(() => this.loadStudents());
    }
  }

  deleteStudent(id: number) {
    if (confirm('Are you sure?')) {
      this.studentService.deleteStudent(id).subscribe(() => this.loadStudents());
    }
  }
}
