export class ObservedChannelMembers {
  constructor() {
    this.data = []
  }

  // 監視ユーザーのON, OFF
  setObserve(channelId, accountId, observe) {
    const member = this.#getChannelMember(channelId, accountId)
    member.observe = observe
  }

  // チャンネルの追加
  registerChannel(channelId, accountIds) {
    if (this.#isRegisterd(channelId)) return

    const members = accountIds.map(id => ({ accountId: id, observe: false }))

    this.data.push({channelId: channelId, members: members})
  }

  // チャンネルの削除
  deleteChannel(channelId) {
    this.data = this.data.filter(d => d.channelId !== channelId)
  }

  #isRegisterd(channelId) {
    const channelIds = this.#getChannelIds()

    if (channelIds.length === 0) return false

    return channelIds.findIndex(id => id === channelId) !== -1
  }

  #getChannelIds() {
    return this.data.map(d => d.channelId)
  }

  #getChannelMember(channelId, accountId) {
    return this.data.find(d => d.channelId === channelId)
               .members.find(m => m.accountId === accountId)
  }
}
