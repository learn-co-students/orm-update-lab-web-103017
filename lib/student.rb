require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name,grade,id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql  = "CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql  = "DROP TABLE students"
    DB[:conn].execute(sql)
  end

  def save
    #inserts new row into database
    #and assigns id from database
    if self.id
      self.update
    else
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end

  end

  def self.create(name,grade)
    #creates new student with name and grade
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    #creates new student object from row array from db
    student = Student.new(row[1],row[2],row[0])
    student
  end

  def self.find_by_name(name)
    #queries database for name, then uses
    #new_from_db to instantiate Student with row from db
    sql = "SELECT * FROM students WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql,name)[0])
  end

  def update
    #updates row mapped to Student instance
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?"
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end


end
