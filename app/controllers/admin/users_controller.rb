# -*- encoding: utf-8 -*-

class Admin::UsersController < ApplicationController
  before_filter :require_login

  def index
    @users = User.includes(:account).find :all
    bookings = Booking.select('account_id, SUM(value) AS value, MAX(updated_at) AS last').where('account_id IN (SELECT account_id FROM accounts INNER JOIN users USING(user_id))').group(:account_id)

    @bookings = {}
    @activities = {}
    bookings.each do |b|
      @bookings[b.account_id] = b.value
      @activities[b.account_id] = DateTime.parse(b.last)
    end
  end

  def show
    @user = User.find params[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    saved = false

    User.transaction do
      saved = true if @user.save and Account.create(user_id: @user.user_id)
    end

    respond_to do |format|
      if saved
        format.html { redirect_to admin_user_url(@user), notice: I18n.t('admin.user.successfully_created') }
        format.json { render json: @user, :status => :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find(params[:id])
    has_saved = false

    if (params[:user][:password].to_s.empty? && @user.update_without_password(params[:user])) or @user.update_attributes(params[:user])
      has_saved = true
    end

    respond_to do |format|
      if has_saved
        format.html { redirect_to edit_admin_user_url(@user), notice: I18n.t('admin.user.successfully_updated') }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: I18n.t('admin.group.successfully_deleted') }
      format.json { head :no_content }
    end
  end
end

# eof