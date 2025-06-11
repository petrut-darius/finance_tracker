class StocksController < ApplicationController
  def search
    unless params[:stock].present?
      respond_to do |format|
        flash[:alert] = "Please enter a symbol to search"
        format.js   { render partial: "users/result", locals: { stock: @stock } }
      end
    end

    @stock = Stock.new_lookup(params[:stock])

    if @stock
      respond_to do |format|
        format.html { render "users/my_portofolio" }
        format.js   { render partial: "users/result", locals: { stock: @stock } }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("results_turbo_stream", partial: "users/results", locals: { stock: @stock })
        end
      end
    else
      flash[:alert] = "You might have reached the API request limit or entered an invalid symbol"
      respond_to do |format|
        flash[:alert] = "You might have reached the API request limit or entered an invalid symbol"
        format.js   { render partial: "users/result", locals: { stock: @stock } }
      end
    end
  end
end
