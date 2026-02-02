class Api::V1::EventsController < ApplicationController
  def index
    events = Event.all
    authorize events
    render json: events
  end

  def create
    event = current_user.events.new(event_params)
    authorize event
    event.save!
    render json: event, status: :created
  end

  def update
    event = Event.find(params[:id])
    authorize event
    event.update!(event_params)
    render json: event
  end

  def destroy
    event = Event.find(params[:id])
    authorize event
   if event.destroy
    render json: { message: "Your record has been successfully deleted" }, status: :ok
   else
    render json: { errors: event.errors.full_messages }, status: :unprocessable_entity
   end
  end

  private
  def event_params
    params.require(:event).permit(:title, :start_time, :capacity, :description, :price)
  end
end
