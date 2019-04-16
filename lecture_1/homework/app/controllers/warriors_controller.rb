# frozen_string_literal: true

class WarriorsController < ApplicationController

  # GET /clans/:clan_id/warriors
  def index
    warriors = params[:alive] ? Warrior.alive : Warrior

    warriors = WarriorsQuery.belonging_to_clan(clan_id: params[:clan_id], relation: warriors)

    warriors = WarriorsQuery.having_birthday(relation: warriors) if params[:birthday]

    warriors = warriors.first(params[:limit].to_i) if params[:limit].present?

    render json: warrior_json(warriors)
  end

  # POST /clans/:clan_id/warriors
  def create
    warrior = WarriorsCreator.new(clan, warrior_params).call
    render json: warrior_json(warrior), status: 201
  end

  # PUT /clans/:clan_id/warriors/:id
  def update
    warrior.update!(warrior_params)
    render json: warrior_json(warrior)
  end

  # DELETE /clans/:clan_id/warriors/:id
  def destroy
    warrior.destroy!
    head 204
  end

  private

  def clan
    Clan.find(params[:clan_id])
  end

  def warrior
    @warrior ||= clan.warriors.find(params[:id])
  end

  def warrior_params
    params.permit(:name, :armor, :battles, :join_date, :death_date, :type, :weapon,
      weapon_attributes: [:id, :damage, :range, :type])
  end

  def warrior_json(warrior)
    @serializer = WarriorSerializer.new(warrior)
    return @serializer.serialized_json
  end

  def filter_warriors(warriors, params)
    warriors = filter_alive(warriors, params[:alive]) if params[:alive].present?
    warriors
  end

end
