require_relative 'test_helper'

class EnumerationsTest < Minitest::Test
  def test_reflect_on_all_enumerations
    enumerations = Post.reflect_on_all_enumerations

    assert_equal 2, enumerations.size
    assert_equal :status, enumerations.first.name
    assert_equal 'Status', enumerations.first.class_name

    assert_equal :some_other_status_id, enumerations[1].foreign_key
  end

  def test_model_enumeration_assignment
    p = Post.new
    p.status = Status.draft

    assert_equal 'Draft', p.status.to_s
  end

  def test_model_bang_assignment
    p = Post.new
    p.status_draft!

    assert_equal 'Draft', p.status.to_s
  end

  def test_model_bang_assignment_with_custom_name
    p = Post.new
    p.different_status_draft!

    assert_equal 'Draft', p.different_status.to_s
  end

  def test_model_via_id_assignment
    p = Post.new
    p.some_other_status_id = Status.published.id

    assert_equal 'Published', p.different_status.to_s
  end

  def test_boolean_lookup
    p = Post.new
    p.status = Status.draft

    assert_equal true, p.status.draft?
  end

  def test_false_boolean_lookup
    p = Post.new
    p.status = Status.draft

    assert_equal false, p.status.published?
  end

  def test_multiple_enumerations_on_model
    enumerations = User.reflect_on_all_enumerations

    assert_equal 2, enumerations.size

    assert_equal :role, enumerations.first.name
    assert_equal :role_id, enumerations.first.foreign_key

    assert_equal :status, enumerations[1].name
    assert_equal :status_id, enumerations[1].foreign_key
  end

  def test_multiple_enumeration_assignments_on_model
    u = User.new
    u.role = Role.admin
    u.status = Status.published

    assert_equal 'Admin', u.role.to_s
    assert_equal 'Published', u.status.to_s
  end

  def test_enumerated_class_has_scopes
    Role.all do |role|
      assert_respond_to User, ['with_role', role.name].join('_').to_sym
    end
  end

  def test_enumerated_class_scope_hash_value
    query_hash = User.with_role_admin.where_values_hash.symbolize_keys

    assert_equal query_hash, role_id: 1
  end
end
