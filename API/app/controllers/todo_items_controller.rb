class TodoItemsController < ApplicationController
  before_action :set_todo_item, only: [:show, :update, :destroy]

  # GET /todo_items
  def index
    @todo_items = TodoItem.all

    render json: @todo_items
  end

  # GET /todo_items/1
  def show
    render json: @todo_item
  end

  # POST /todo_items
  def create
    @todo_item = TodoItem.new(todo_item_params)

    if @todo_item.save
      render json: @todo_item, status: :created, location: @todo_item
    else
      render json: @todo_item.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /todo_items/1
  def update
    if @todo_item.update(todo_item_params)
      render json: @todo_item
    else
      render json: @todo_item.errors, status: :unprocessable_entity
    end
  end

  # DELETE /todo_items/1
  def destroy
    @todo_item.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo_item
      @todo_item = TodoItem.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def todo_item_params
      params.require(:todo_item).permit(:title)
    end
end
