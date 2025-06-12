class StocksController < ApplicationController
  def search
    unless params[:stock].present?
      flash.now[:alert] = "Please enter a symbol to search"
      return render turbo_stream: turbo_stream.replace(
        "results_turbo_stream",
        partial: "users/result",
        locals: { stock: nil }
      )
    end

    @stock = Stock.new_lookup(params[:stock])

    if @stock
      render turbo_stream: turbo_stream.replace(
          "results_turbo_stream",
          partial: "users/result",
          locals: { stock: @stock }
      )
    else
      flash[:alert] = "You might have reached the API request limit or entered an invalid symbol"
        render turbo_stream: turbo_stream.replace(
          "results_turbo_stream",
          partial: "users/result",
          locals: { stock: nil }
        )
    end
  end
end
