# frozen_string_literal: true

alice = User.create(
  name: 'alice',
  email: 'test@example.com',
  password: 'testtest'
)

User.create(
  name: 'bob',
  email: 'test1@example.com',
  password: 'testtest'
)
