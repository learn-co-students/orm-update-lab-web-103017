require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id=nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if @id == nil
    sql = <<-SQL
      INSERT INTO students
      (name, grade)
      VALUES
      (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  else
    self.update
  end
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(input)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, input).flatten
    self.new_from_db(row)
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)

  end






end
