export class ObservedChannelMembers {
  constructor() {
    this.data = []
    this.notDestroyChannelIds = []
  }

  // 監視ユーザーのON, OFF
  setObserve(channelId, channelMemberId, observe) {
    const member = this.#getChannelMember(channelId, channelMemberId)
    member.observe = observe
  }

  // チャンネルの追加
  registerChannel(channelId, channelMembersInfo, { destroy = true }) {
    if (this.#isRegisterd(channelId)) return

    const members = channelMembersInfo.map(channelMemberInfo => 
      ({ channel_member_id: channelMemberInfo.channel_member_id, observe: channelMemberInfo.observe }))

    this.data.push({channel_id: channelId, members: members})
    
    if (!destroy) {
      this.notDestroyChannelIds.push(channelId)
    }
  }

  // チャンネルの削除
  // チャンネルの削除フラグがONの場合は、チャンネルとチャンネル内メンバーを削除
  // チャンネルの削除フラグがOFFの場合は、監視対象ユーザーをOFFにする
  deleteChannel(channelId) {
    if (this.notDestroyChannelIds.findIndex(id => id === channelId) === -1) {
      this.data = this.data.filter(d => d.channel_id !== channelId)
    } else {
      const channelMembers = this.#getChannelMembers(channelId)
      channelMembers.forEach((channelMember) => {
        channelMember.observe = false
      })
    }
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

  #getChannelMembers(channelId) {
    return this.data.find(d => d.channel_id === channelId).members
  }

  #getChannelMember(channelId, channelMemberId) {
    return this.data.find(d => d.channel_id === channelId)
               .members.find(m => m.channel_member_id === channelMemberId)
  }
}
