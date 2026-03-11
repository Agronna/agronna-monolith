# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    # Dono da conta ou admin
    if user.account_owner? || user.admin?
      can :manage, User
      can :manage, Secretary

    elsif user.sub_admin?
      can %i[read update], User, id: user.id
      can %i[read create update], Secretary

    else
      can %i[read update], User, id: user.id
      can :read, Secretary
    end
  end
end
