export class ObservedChannelMembers {
  constructor() {
    this.data = []
  }

  // 監視ユーザーのON, OFF
  setObserve(channelId, channelMemberId, observe) {
    const member = this.#getChannelMember(channelId, channelMemberId)
    member.observe = observe
  }

  // チャンネルの追加
  registerChannel(channelId, accountIds) {
    if (this.#isRegisterd(channelId)) return

    const members = accountIds.map(id => ({ channel_member_id: id, observe: false }))

    this.data.push({channel_id: channelId, members: members})
  }

  // チャンネルの削除
  deleteChannel(channelId) {
    this.data = this.data.filter(d => d.channel_id !== channelId)
  }

  getData() {
    return JSON.parse(JSON.stringify(this.data))
  }

  #isRegisterd(channelId) {
    const channelIds = this.#getChannelIds()

    if (channelIds.length === 0) return false

    return channelIds.findIndex(id => id === channelId) !== -1
  }

  #getChannelIds() {
    return this.data.map(d => d.channel_id)
  }

  #getChannelMember(channelId, channelMemberId) {
    return this.data.find(d => d.channel_id === channelId)
               .members.find(m => m.channel_member_id === channelMemberId)
  }
}
