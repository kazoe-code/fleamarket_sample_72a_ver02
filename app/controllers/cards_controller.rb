class CardsController < ApplicationController

  require "payjp"
  
  before_action :sign_in_required
  after_action :session_clear, only: [:show]

  add_breadcrumb 'TOP', :root

  def new
    # sessionにひとつ前のリファラーをいれる # URLを保存する処理
    session[:previous_url] = request.referer
    
    @card = Card.where(user_id: current_user.id) 
    redirect_to action: "show" if @card.exists?
  
    add_breadcrumb 'お支払い方法', ""
  end

  def pay
    Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
    if params['payjp-token'].blank?
      redirect_to action: "new"
    else
      customer = Payjp::Customer.create(
      description: '登録テスト', 
      email: current_user.email, 
      card: params['payjp-token'],
      metadata: {user_id: current_user.id}
      ) 
      @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)

      if @card.save
        redirect_to action: "show"
      else
        redirect_to action: "pay"
      end
    end
  end

  def delete
    @card = Card.where(user_id: current_user.id).first
    if @card.blank?
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      @customer = Payjp::Customer.retrieve(@card.customer_id)
      @customer.delete
      @card.delete
    end
      redirect_to action: "new"
  end

  def show 
    # sessionの中からURLを取り出してリダイレクトさせる
    @session = session[:previous_url]
    @card = Card.where(user_id: current_user.id).first
    if @card.blank?
      redirect_to action: "new" 
    else
      Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @default_card_information = customer.cards.retrieve(@card.card_id)
    end
      add_breadcrumb 'マイページ', "/users/#{current_user.id}"
      add_breadcrumb 'カード情報', ""
  end

  private

  def sign_in_required
    redirect_to new_user_session_url unless user_signed_in?
  end

# sessionをクリア
  def session_clear
    session[:previous_url].clear
  end

end