CanCan::Ability.module_eval do
  def relevant_rules(action, subject, attribute = nil)
    rules.reverse.select do |rule|
      rule.expanded_actions = expand_actions(rule.actions)
      rule.relevant? action, subject, attribute
    end
  end

  def relevant_rules_for_match(action, subject, attribute = nil)
    relevant_rules(action, subject, attribute).each do |rule|
      if rule.only_raw_sql?
        raise ::Exception, "The can? and cannot? call cannot be used with a raw sql 'can' definition. The checking code cannot be determined for #{action.inspect} #{subject.inspect}"
      end
    end
  end

  def can?(action, subject, attribute = nil)
    match = relevant_rules_for_match(action, subject, attribute).detect do |rule|
      rule.matches_conditions?(action, subject, attribute)
    end
    match ? match.base_behavior : false
  end

  def can(*args, &block)
    rules << CanCan::Rule.new(true, *args, &block)
  end

  def cannot(*args, &block)
    rules << CanCan::Rule.new(false, *args, &block)
  end
end
