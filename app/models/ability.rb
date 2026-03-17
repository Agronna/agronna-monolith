# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    # Dono da conta ou admin
    if user.account_owner? || user.admin?
      can :manage, User
      can :manage, Secretary
      can :manage, Producer
      can :manage, Machine
      can :manage, Property
      can :manage, ServiceProvider
      can :manage, ServiceOrder
      can :manage, PaymentReceipt

    elsif user.sub_admin?
      can %i[read update], User, id: user.id
      can %i[read create update], Secretary
      can %i[read create update], Producer
      can %i[read create update], Machine
      can %i[read create update], Property
      can %i[read create update], ServiceProvider
      can %i[read create update], ServiceOrder
      can %i[read create update], PaymentReceipt

    else
      can %i[read update], User, id: user.id
      can :read, Secretary
      can :read, Producer
      can :read, Machine
      can :read, Property
      can :read, ServiceProvider
      can :read, ServiceOrder
      can :read, PaymentReceipt
    end
  end
end
