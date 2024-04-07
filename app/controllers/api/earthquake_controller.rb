# frozen_string_literal: true

class Api::EarthquakeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create_comment]

  def index
    earthquakes = Earthquake.all
    earthquakes = filter_by_mag_type(earthquakes, params[:mag_type].split(',')) if params[:mag_type].present?

    earthquakes = paginate(earthquakes, params[:page], params[:per_page])

    render json: serialize(earthquakes, params[:page], earthquakes.count, params[:per_page])
    # render json:earthquakes
  end

  def create_comment

    @earthquake = Earthquake.find(params[:id])
    @comment = @earthquake.comments.create(comment_params)
    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def filter_by_mag_type(earthquakes, mag_types)
    mag_types.each do |mag_type|
      earthquakes = earthquakes.or({ mag_type: mag_type })
    end
    earthquakes
  end

  def paginate(earthquakes, page, per_page)
    page = page.to_i
    per_page = per_page.to_i
    per_page = 1000 if per_page > 1000
    earthquakes = earthquakes.skip((page - 1) * per_page).limit(per_page)
    earthquakes
  end

  def serialize(earthquakes, current_page, total, per_page)
    {
      data: earthquakes.map do |earthquake|
        {
          id: earthquake.id,
          type: "feature",
          attributes: {
            external_id: earthquake.id,
            magnitude: earthquake.mag,
            place: earthquake.place,
            time: earthquake.time.to_s,
            tsunami: earthquake.tsunami,
            mag_type: earthquake.mag_type,
            title: earthquake.title,
            comments: earthquake.comments.map do |comment|
              {
                id: comment.id,
                body: comment.body
              }
            end,
            coordinates: {
              longitude: earthquake.longitude,
              latitude: earthquake.latitude
            }
          },
          links: {
            external_url: earthquake.url
          }
        }
      end,
      pagination: {
        current_page: current_page,
        total: total,
        per_page: per_page
      }
    }
  end

end
