# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    # Dono da conta (administrador principal) ou admin: pode gerenciar usuários da conta
    if user.account_owner? || user.admin?
      can :manage, User
    elsif user.sub_admin?
      can %i[read update], User, id: user.id
    else
      can %i[read update], User, id: user.id
    end
  end
end
