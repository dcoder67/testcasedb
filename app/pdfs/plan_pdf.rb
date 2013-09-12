class PlanPdf < Prawn::Document
  def initialize(test_plan, view)
    super()
    @test_plan = test_plan
    @view = view
    stroke_color 'e00000'
    test_plan_title_page
    test_plan_page
    print_test_cases
  end
  
  def test_plan_title_page
    move_down 250
    text "Test Plan: #{@test_plan.name}", :size => 25, :style => :bold
    text "#{@test_plan.description}", :size => 15
    move_down 20
    text "Version: #{@test_plan.version}"
    move_cursor_to 10
    text "Generated by TestCaseDB", :size => 9
    start_new_page
  end
  
  def test_plan_page
    text "<b>Test Plan:</b> #{@test_plan.name}", :inline_format => true
    text "<b>Description</b>: #{@test_plan.description}", :inline_format => true
    text "<b>Version:</b> #{@test_plan.version}", :inline_format => true
    text "<b>Product:</b> #{@test_plan.product.name}", :inline_format => true
    move_down 20
    text "Test Cases", :style => :bold
    stroke_horizontal_rule
    move_down 10
    print_test_cases_list
    start_new_page
  end
  
  def print_test_cases_list
    table list_test_cases do
      row(0).font_style = :bold
      self.row_colors = ["EEEEEE", "FFFFFF"]
      self.header = true
    end
  end

  def list_test_cases()
    [["Name", "Product", "Category", "Version", "Description"]] +
    @test_plan.test_cases.order("case_order").map do |test_case|
      [test_case.name, test_case.product.name, @view.CategoryPathName(test_case.category_id), test_case.version, test_case.description]
    end
  end
  
  def print_test_cases
    text "Test Cases", :size => 15, :style => :bold
    stroke_horizontal_rule
    stroke_color '000000'
    move_down 10
    @test_plan.test_cases.order("case_order").each do |test_case|
      text "<b>Test Case:</b> #{test_case.name}", :size => 12, :inline_format => true
      text "<b>Product:</b> #{test_case.product.name}", :inline_format => true
      text "<b>Category:</b> #{@view.CategoryPathName(test_case.category_id)}", :inline_format => true
      text "<b>Version:</b> #{test_case.version}", :inline_format => true
      text "<b>Description:</b> #{test_case.description}", :inline_format => true
      move_down 5
      print_steps(test_case)
      move_down 10
      stroke_horizontal_rule
      move_down 20
    end
  end
  
  def print_steps(test_case)
    move_down 15
    table step_rows(test_case) do
      row(0).font_style = :bold
      self.row_colors = ["EEEEEE", "FFFFFF"]
      self.header = true
    end
  end

  def step_rows(test_case)
    [["", "Action", "Expected Result"]] +
    test_case.steps.order("step_number").map do |step|
      [step.step_number, step.action, step.result]
    end
  end

end